/*
 * bootstrap.go - Nested Container Environment Bootstrap file.
 * (c) 2019 Sam Caldwell.  See LICENSE.txt.
 *
 * This file is the bootstrap for a nested container environment
 * which, when compiled into a binary and included in a Dockerfile
 * will allow a privileged wrapper container to be constructed which
 * can run lesser-privileged child containers for a single-unit
 * of an application stack with minimum overhead.
 *
 * ToDo: Create signal handler for graceful termination on <ctrl-C>
 */
package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
)

/*
 * Our Manifest array defines the set of child services which
 * will be spawned by our wrapper container.  Thus when we start
 * the wrapper container, it will execute this program as its
 * ENTRYPOINT and start the child container services while also
 * providing its own health check (HTTP) endpoint.
 */

var Manifest = []Service{
	Service{
		Name:      "myapp",
		Image:     "ubuntu",
		Tag:       "latest",
		OuterPort: 8080,
		InnerPort: 8080,
	},
	Service{
		Name:      "myapp1",
		Image:     "ubuntu",
		Tag:       "latest",
		OuterPort: 8081,
		InnerPort: 8081,
	},
}

/*
 * Config defines the general configuration parameters for
 * the wrapper container.  These are pulled from op/sys
 * environment variables with defaults specified in this
 * file.
 */
var Config = Configuration{
	HealthCheckAddr: GetEnv("HealthCheckAddr", "0.0.0.0:1337"),
}

//
// -----------------------------------------------------------------------------
// Do not alter below this point unless you are changing the core functionality.
// -----------------------------------------------------------------------------
//

/*
 * Our Configuration struct defines the eligible properties for
 * our wrapper bootstrap program.
 */
type Configuration struct {
	HealthCheckAddr string
}

/*
 * Our Service struct defines the eligible properties of a
 * child container.
 */
type Service struct {
	Name      string
	Tag       string
	Image     string
	OuterPort uint16 // 0-65535
	InnerPort uint16 // 0-65535
}

func main() {
	if os.Args[1] == "noop" {
		fmt.Printf("OK")
		os.Exit(0)
	}
	fmt.Println("Starting...")
	go StartHealthCheckServer(Config.HealthCheckAddr)
	fmt.Printf("Healthcheck ready at %s", Config.HealthCheckAddr)
	for _, svc := range Manifest {
		port := fmt.Sprintf("%d:%d", svc.OuterPort, svc.InnerPort)
		fmt.Printf("Name:%s\n", svc.Name)
		fmt.Printf("Tag:%s\n", svc.Tag)
		fmt.Printf("Image:%s\n", svc.Image)
		fmt.Printf("Port:%s\n", port)
		fmt.Println()

		cmd:="docker"
		//
		// Setup the basic arguments and drop all capabilities.
		//
		args := []string{
			"run",
			"-d",
			"--cap-drop",
			"ALL",
			"--name",
			svc.Name,
		}
		//
		// If the networking is disabled (zero-value ports), then leave all capabilities dropped.
		// Otherwise we need to add some capabilities so the network can be reached.
		//
		if !(svc.InnerPort == 0 && svc.OuterPort == 0) {
			// Add network capabilities.
			args = append(args, "--cap-add")
			args = append(args, "CAP_NET_RAW")
			args = append(args, "--cap-add")
			args = append(args, "CAP_NET_BROADCAST")
			args = append(args, "--cap-add")
			args = append(args, "CAP_NET_RAW")
			args = append(args, "--cap-add")
			args = append(args, "CAP_NET_ADMIN")
			if svc.InnerPort < 1024 {
				args = append(args, "--cap-add")
				args = append(args, "CAP_NET_BIND_SERVICE")
			}
		}
		//
		// Finally append the image and tag to the arguments slice.
		//
		args = append(args, fmt.Sprintf("%s:%s", svc.Image, svc.Tag))
		//
		// Next execute `docker run` to start the container.
		//
		if err := exec.Command(cmd, args...).Run(); err != nil {
			fmt.Printf("Error running (%s): %v\n", svc.Name, err)
			os.Exit(1)
		}
		fmt.Println("Child containers started.")
	}
	fmt.Println("Running.")
	/*
	 * Start: Intercept and handle ctrl-c handler.
	 */
	signalChan := make(chan os.Signal, 1)
	cleanupDone := make(chan struct{})
	signal.Notify(signalChan, os.Interrupt)
	go func() {
		<-signalChan
		fmt.Println("\nReceived an interrupt, stopping services...")
		close(cleanupDone)
	}()
	<-cleanupDone
	/*
	 * End: Intercept and handle ctrl-c handler.
	 */
	fmt.Println("Exiting.")
}

func StartHealthCheckServer(addr string) {
	http.HandleFunc("/",
		func(w http.ResponseWriter, r *http.Request) {
			var err error
			_, err = fmt.Fprintf(w, "OK")
			if err != nil {
				panic("healthcheck (wrapper container) failed to write.")
			}
		})
	log.Fatal(http.ListenAndServe(addr, nil))
}

func GetEnv(key, defaultValue string) string {
	//ToDo: Create a vault encrypted store source for secrets.
	value := os.Getenv(key)
	if len(value) == 0 {
		return defaultValue
	}
	return value
}
