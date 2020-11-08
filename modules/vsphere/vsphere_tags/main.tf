resource "vsphere_tag_category" "category" {
    name            = var.tag_category
    cardinality     = var.category_cardinality
    description     = "Managed by Terraform"

}

resource "vsphere_tag" "tag" {
    name            = var.tag
    category        = "${vsphere_tag_category.category.id}"
    description     = "Managed by Teraform"
}