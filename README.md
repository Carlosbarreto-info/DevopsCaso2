# DevopsCaso2
Caso2 Devops Unir


                  +--------------------------------------------------------+
                  |                    Microsoft Azure                       |
                  +--------------------------------------------------------+
                                           |
                   +-----------------------+------------------------+
                   |                       |                        |
          Azure Container          Máquina Virtual con Podman    Azure Kubernetes
              Registry                                           Service (AKS)
                   |                       |                        |
      +------------+-------------+         |          +-------------+--------------+
      |            |             |         |          |            |              |
  Repositorio   Contenedor     Servicio    |   Nodo de      Cluster AKS   Aplicación en
  de Imágenes   con Podman     Web         |   Máquina                        Kubernetes
  (ACR)                           (Apache) |   Virtual                     (MongoDB)
                                           |
                                +----------+-----------+
                                |                      |
                             Almacenamiento         Almacenamiento
                             Persistente (VM)       Persistente (AKS)





Este código de Terraform esta diseñado para crear una infraestructura en Azure que incluye una red virtual, subredes, máquinas virtuales, grupos de seguridad de red, un registro de contenedor de Azure (ACR) y un servicio de Kubernetes de Azure (AKS). Aquí hay un resumen de lo que hace cada recurso:

Proveedor de Azure: Declara el proveedor de Azure y especifica la versión mínima requerida.

Grupo de Recursos: Crea un grupo de recursos en Azure.

Red Virtual y Subred: Crea una red virtual en Azure con una subred especificada.

IP Pública y Grupo de Seguridad de Red: Crea una IP pública y un grupo de seguridad de red para las VMs.

Máquinas Virtuales: Crea máquinas virtuales Linux en Azure.

Interfaces de Red: Crea interfaces de red para las máquinas virtuales.

Asociación de Grupo de Seguridad de Red con Interfaces de Red: Asocia el grupo de seguridad de red creado anteriormente con las interfaces de red de las máquinas virtuales.

Registro de Contenedor de Azure (ACR): Crea un registro de contenedor en Azure.

Servicio de Kubernetes de Azure (AKS): Crea un clúster de Kubernetes en Azure.




                             
