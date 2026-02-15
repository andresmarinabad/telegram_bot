terraform {
  backend "gcs" {
    bucket  = "oceanic-cache-487515-g5-tfstate"
    prefix  = "terraform/state"
  }
}