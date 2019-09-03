package main

import (
	"strings"
	"testing"
)

func TestBootstrapManifest(t *testing.T) {
	seenNames := make(map[string]Service)
	seenInnerPorts := make(map[uint16]Service)
	seenOuterPorts := make(map[uint16]Service)
	/*
	 * Iterate through the Manifest values and detect any problems that would prevent a successful deployment
	 * of a contained-bootstrap binary as the config of a contained container solution.
	 */
	for _, svc := range Manifest {
		/*
		 * Iterate through all of the services in the manifest and perform basic checks.
		 *
		 * Check 1.0: Ensure Name (string) is not empty.
		 */
		if strings.TrimSpace(svc.Name) == "" {
			t.Errorf("Error: Name cannot be empty.")
		} else {
			t.Logf("Confirmed Service name: %s", svc.Name)
		}
		/*
		 * Check 1.1: Ensure Image (string) is not empty.
		 */
		if strings.TrimSpace(svc.Image) == "" {
			t.Errorf("Error: Image cannot be empty.")
		} else {
			t.Logf("Confirmed Image name (%s) for service name %s", svc.Image, svc.Name)
		}
		/*
		 * Check 1.2: Ensure Tag (string) is not empty.
		 */
		if strings.TrimSpace(svc.Tag) == "" {
			t.Errorf("Error: Tag cannot be empty.")
		} else {
			t.Logf("Confirmed Service Tag (%s) for service name %s", svc.Tag, svc.Name)
		}
		/*
		 * Check 2.0: Ensure that the network port values are within range, where
		 * 				0       : Disabled network
		 *				1-65535 : Non-disabled network.
		 *
		 * 				If one port is disabled, the other must be disabled as well.
		 */
		if (svc.InnerPort == uint16(0)) || (svc.OuterPort == uint16(0)) {
			/*
			 * One or both port values are disabled (zero value).
			 */
			t.Logf("Check: One or both ports are disabled (zero value).")

			if (svc.InnerPort < uint16(0)) || (svc.InnerPort > uint16(65535)) {
				t.Errorf("Error: InnerPort value must be 1..65535 (0 will disable networking).")
			} else {
				t.Logf("Confirmed Service InnerPort (%d) for service name %s", svc.InnerPort, svc.Name)
			}

			if (svc.OuterPort < uint16(0)) || (svc.OuterPort > uint16(65535)) {
				t.Errorf("Error: OuterPort value must be 1..65535 (0 will disable networking).")
			} else {
				t.Logf("Confirmed Service OuterPort (%d) for service name %s", svc.OuterPort, svc.Name)
			}
			t.Logf("Confirmed service named '%s' is properly configured for networking.", svc.Name)
		} else {
			/*
			 * Niether port value is zero (0).  So networking is enabled.
			 */
			if (svc.InnerPort != uint16(0)) && (svc.OuterPort != uint16(0)) {
				t.Logf("Confirmed networking is enabled for %s", svc.Name)
			} else {
				/*
				 * This is an error state.  One value is zero but the other is non-zero.
				 */
				t.Errorf("Error: Inner or outer port is zero (0) but the other is non-zero for %s", svc.Name)
			}
		}
		/*
		 * check for duplicate services entries (name)
		 */
		if dupSvc, ok := seenNames[svc.Name]; ok {
			t.Errorf("A duplicate Service Name exists in bootstrap.go Manifest: %s", dupSvc.Name)
		} else {
			seenNames[svc.Name] = svc
		}
		/*
		 * Check for duplicate ports.
		 */
		if dupSvc, ok := seenInnerPorts[svc.InnerPort]; ok {
			t.Errorf(
				"A duplicate Inner port (%d) is defined for services '%s' and '%s'",
				svc.InnerPort,
				svc.Name,
				dupSvc.Name)
		} else {
			seenInnerPorts[svc.InnerPort] = svc
			t.Logf("Confirmed InnerPort for %s has no duplicate for port %d", dupSvc.Name, dupSvc.InnerPort)
		}
		if dupSvc, ok := seenOuterPorts[svc.OuterPort]; ok {
			t.Errorf(
				"A duplicate Outer port (%d) is defined for services '%s' and '%s'",
				svc.OuterPort,
				svc.Name,
				dupSvc.Name)
		} else {
			seenOuterPorts[svc.OuterPort] = svc
			t.Logf("Confirmed OuterPort for %s has no duplicate for port %d", dupSvc.Name, dupSvc.OuterPort)
		}

	}
}
