locals {
rg_name="rgg"
location= "East US"
vn = {
    name= "VN1"
    address_space = "10.0.0.0/16"
  }

VM_name = "VM1"
VN_name = "VN1"


subnet = [
    {
      name="subnet1"
      address_prefix= "10.0.0.0/24"
    },
    {  
      name="subnet2"
      address_prefix= "10.0.1.0/24"
    }

  ]

}

//below are the resources for second test

locals {
rg_name2 = "say22"
location2 = "East US"



VN2 = {
      name = "VN2",
      address_space = "10.0.0.0/24"
}

VN4 = {
    name = "VN4"
    address_space = "10.12.0.0/22"

  }
subnet22 = [ {
  name = "subnet1"
  address_prefix = "10.0.0.0/24"
        },

  {name = "subnet2"
  address_prefix = "10.0.1.0/24" 


}
]
//below are the resources for third test

rg3 = "RG3"
vn3 = {
  name = "vn3"
  address_space = "10.12.0.0/24"
}

subnet33 = [
  {
    name = "subnet5"
    address_prefixes = "10.12.0.0/24"
  },

  {
    name = "subnet6"
    address_prefixes = "10.12.1.0/24"
  }



]

Subnet4 = [
    {
      name = "subnet7"
      address_prefixes = "10.12.0.0/22"

    }

    {
      name = "subnet8"
      address_prefixes = "10.12.0.1/22"

    }

  ]
}

//below are the resources for third test





