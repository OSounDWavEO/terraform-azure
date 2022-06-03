resource "random_shuffle" "az" {
	input			= var.az
	result_count	= 1
}