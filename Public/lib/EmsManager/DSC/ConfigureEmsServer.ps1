configuration ConfigureEmsServer {
    param(
        [Parameter( Mandatory = $true )]
        [PSCredential] $DomainAdmin
    )

    node localhost {

    }
}
