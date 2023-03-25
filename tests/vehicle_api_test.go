package tests

import (
  http_helper "github.com/gruntwork-io/terratest/modules/http-helper"

  "github.com/gruntwork-io/terratest/modules/terraform"

  "testing"
  "time"
  "fmt"
//"os"
)

func TestTerraformModule(t *testing.T) {
  options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
    TerraformDir: "..",
    Vars: map[string]interface{}{
      "openapi_spec_path": "./tests/vars/openapi.yml",
      "code_path":         "./tests/vars/vehicle_api",
      "zone_name":         "292372118261.starfish-rentals.com",
      "app_handler":       "resolver.handler",
      "app_version":       "v0.0.xx",
      "env":               "sandbox",
    },
  })

  defer terraform.Destroy(t, options)
  terraform. InitAndApply(t, options)

  domainName := terraform.Output(t, options, "domain_name")

  url :=  fmt.Sprintf("HTTPS://%s/v1", domainName)
  http_helper.HttpGetWithRetry(
    t, url, nil, 200, "Hello World!", 30, 10 * time.Second,
  )

  // Test DDB
  // Test WAF
  // ...
}
