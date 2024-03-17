# Escrito y documentado por Carlos Barreto para Caso 2 Unir Devops, sedo este codigo para ser usado con fines educativos.

# Configuración del proveedor y versión mínima de Terraform
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.85.0"
    }
  }
}
# Proveedor de Azure
provider "azurerm" {
  features {}
}

# Grupo de Recursos
resource "azurerm_resource_group" "network" {
  name     = "network-resources" # Nombre del grupo de recursos
  location = "East US"           # Ubicación del grupo de recursos
}

# Red Virtual y Subred
resource "azurerm_virtual_network" "mimicaso2_network" {
  name                = "mimicaso2-virtual-network"             # Nombre de la red virtual
  address_space       = ["10.0.0.0/16"]                         # Rango de direcciones IP de la red
  location            = azurerm_resource_group.network.location # Ubicación de la red
  resource_group_name = azurerm_resource_group.network.name     # Nombre del grupo de recursos
}

resource "azurerm_subnet" "mimicaso2_subnet" {
  name                 = "mimicaso2-subnet"                                    # Nombre de la subred
  virtual_network_name = azurerm_virtual_network.mimicaso2_network.name        # Nombre de la red virtual asociada
  address_prefixes     = ["10.0.1.0/24"]                                       # Rango de direcciones IP de la subred
  resource_group_name  = azurerm_resource_group.network.name                   # Nombre del grupo de recursos
}

# IP Pública y Grupo de Seguridad de Red (NSG) para las VMs
resource "azurerm_public_ip" "mimicaso2_public_ip" {
  name                = "mimicaso2-public-ip"                                  # Nombre de la IP pública
  location            = azurerm_resource_group.network.location                # Ubicación de la IP pública
  resource_group_name = azurerm_resource_group.network.name                    # Nombre del grupo de recursos
  allocation_method   = "Dynamic"                                              # Método de asignación de la IP
}

resource "azurerm_network_security_group" "mimicaso2_security_group" {
  name                = "mimicaso2-security-group"                            # Nombre del grupo de seguridad de red
  location            = azurerm_resource_group.network.location               # Ubicación del grupo de seguridad de red
  resource_group_name = azurerm_resource_group.network.name                   # Nombre del grupo de recursos

  # Regla de seguridad para permitir el tráfico SSH
  security_rule {
    name                       = "SSH"                                       # Nombre de la regla
    priority                   = 1001                                        # Prioridad de la regla
    direction                  = "Inbound"                                   # Dirección del tráfico
    access                     = "Allow"                                     # Acceso permitido
    protocol                   = "Tcp"                                       # Protocolo TCP
    source_port_range          = "*"                                         # Rango de puertos de origen
    destination_port_range     = "22"                                        # Puerto de destino (SSH)
    source_address_prefix      = "*"                                         # Prefijo de direcciones de origen
    destination_address_prefix = "*"                                         # Prefijo de direcciones de destino
  }

  # Regla de seguridad para permitir el tráfico HTTP en el puerto 8080
  security_rule {
    name                       = "httpRule"                                  # Nombre de la regla
    priority                   = 1002                                        # Prioridad de la regla
    direction                  = "Inbound"                                   # Dirección del tráfico
    access                     = "Allow"                                     # Acceso permitido
    protocol                   = "Tcp"                                       # Protocolo TCP
    source_port_range          = "*"                                         # Rango de puertos de origen
    destination_port_range     = "8080"                                      # Puerto de destino (HTTP)
    source_address_prefix      = "*"                                         # Prefijo de direcciones de origen
    destination_address_prefix = "*"                                         # Prefijo de direcciones de destino
  }

 # Regla de seguridad para permitir el tráfico HTTP en el puerto 27017
  security_rule {
    name                       = "mongodb"                                  # Nombre de la regla
    priority                   = 1003                                        # Prioridad de la regla
    direction                  = "Inbound"                                   # Dirección del tráfico
    access                     = "Allow"                                     # Acceso permitido
    protocol                   = "Tcp"                                       # Protocolo TCP
    source_port_range          = "*"                                         # Rango de puertos de origen
    destination_port_range     = "27017"                                     # Puerto de destino (HTTP)
    source_address_prefix      = "*"                                         # Prefijo de direcciones de origen
    destination_address_prefix = "*"                                         # Prefijo de direcciones de destino
  }
}

# Máquina Virtual
resource "azurerm_linux_virtual_machine" "mimicaso2vm" {
  for_each            = { for idx in range(1): idx => idx }                   # Bucle para crear múltiples VMs
  admin_username      = "adminUsername"                                       # Nombre de usuario administrador
  name                = "mimicaso2-vm-${each.value}"                          # Nombre de la máquina virtual
  location            = azurerm_resource_group.network.location               # Ubicación de la VM
  resource_group_name = azurerm_resource_group.network.name                   # Nombre del grupo de recursos
  size                = "Standard_DS1_v2"                                     # Tamaño de la VM

  admin_ssh_key {
    username  = "adminUsername"                                               # Nombre de usuario SSH
    public_key = file("~/.ssh/id_rsa.pub")                                    # Ruta a la clave pública SSH
  }

  source_image_reference {
    publisher = "Canonical"						     # Editor de la imagen
    offer     = "0001-com-ubuntu-server-jammy" 				     
    sku       = "22_04-lts"
    version   = "latest"    
  }

  network_interface_ids = [azurerm_network_interface.mimicaso2_nic[each.value].id]  # IDs de las interfaces de red

  os_disk {
    caching              = "ReadWrite"                                        # Tipo de almacenamiento para el disco del sistema
    storage_account_type = "Standard_LRS"                                     # Tipo de cuenta de almacenamiento
  }
}

resource "azurerm_network_interface" "mimicaso2_nic" {
  count               = 1                                                     # Crear nº interfaces de red
  name                = "mimicaso2-nic-${count.index}"                        # Nombre de la interfaz de red
  location            = azurerm_resource_group.network.location               # Ubicación de la interfaz de red
  resource_group_name = azurerm_resource_group.network.name                   # Nombre del grupo de recursos

  ip_configuration {
    name                          = "internal"                                # Nombre de la configuración de IP
    subnet_id                     = azurerm_subnet.mimicaso2_subnet.id        # ID de la subred asociada
    private_ip_address_allocation = "Dynamic"                                 # Asignación de dirección IP privada
  }
}

resource "azurerm_network_interface_security_group_association" "mimicaso2_nic_sg_association" {
  count                     = 1                                               # Asociar nº interfaces de red al grupo de seguridad
  network_interface_id      = azurerm_network_interface.mimicaso2_nic[count.index].id  # ID de la interfaz de red
  network_security_group_id = azurerm_network_security_group.mimicaso2_security_group.id  # ID del grupo de seguridad de red
}

# Registro de Contenedor de Azure (ACR)
resource "azurerm_container_registry" "caso2acr" {
  name                = "caso2acr"
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  sku                 = "Basic"
}


# Clúster de Kubernetes
resource "azurerm_kubernetes_cluster" "az_aks" {
  name                = "az_AKS"                                              # Nombre del clúster de Kubernetes
  location            = "East US"                                             # Ubicación del clúster
  resource_group_name = azurerm_resource_group.network.name                   # Nombre del grupo de recursos
  dns_prefix          = "aks"                                                 # Prefijo DNS del clúster

  default_node_pool {
    name            = "agentpool"                                             # Nombre del pool de nodos
    node_count      = 1                                                        # Número de nodos
    vm_size         = "Standard_DS2_v2"                                       # Tamaño de la VM para los nodos
  }

  identity {
    type = "SystemAssigned"                                                    # Tipo de identidad
  }

  tags = {
    Environment = "Caso2"                                                      # Etiqueta para el entorno
  }
}
