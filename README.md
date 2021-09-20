# Front Door Standard/Premium (Preview) with App Service origin and private endpoint

> (originally from: https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.network/front-door-premium-app-service-private-link)

This template deploys a Front Door Standard/Premium (Preview) with an App Service origin, using a private endpoint to access the App Service application.

## Sample overview and deployed resources

This sample template creates an App Service app and a Front Door profile, and uses a private endpoint (also known as Private Link) to access the App Service.

The following resources are deployed as part of the solution:

### App Service
- App Service plan and application.
  - The App Service plan must use a [SKU that supports private endpoints](https://docs.microsoft.com/azure/app-service/networking/private-endpoint).

### Front Door Standard/Premium (Preview)
- Front Door profile, endpoint, origin group, origin, and route to direct traffic to the App Service application.
  - This sample must be deployed using the premium Front Door SKU, since this is required for Private Link integration.
  - The Front Door origin is configured to use Private Link. The behaviour of App Service (as of February 2021) is that, once a private endpoint is configured on an App Service instance, [that App Service application will no longer accept connections directly from the internet](https://docs.microsoft.com/azure/app-service/networking/private-endpoint). Traffic must flow through Front Door for it to be accepted by App Service.

The following diagram illustrates the components of this sample.

![Architecture diagram showing traffic inspected by App Service access restrictions.](images/appservice-private-endpoint.png)

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

### Connect

Once you have deployed the Azure Resource Manager template, you need to approve the private endpoint connection. This step is necessary because the private endpoint created by Front Door is deployed into a Microsoft-owned Azure subscription, and cross-subscription private endpoint connections require explicit approval. To approve the private endpoint:
1. Open the Azure portal and navigate to the App Service application.
2. Click the **Networking** tab, and then click **Configure your private endpoint connections**.
3. Select the private endpoint that is awaiting approval, and click the **Approve** button. This can take a couple of minutes to complete.

After approving the private endpoint, wait a few minutes before you attempt to access your Front Door endpoint to allow time for Front Door to propagate the settings throughout its network.

You can then access the Front Door endpoint. The hostname is emitted as an output from the deployment - the output is named `frontDoorEndpointHostName`. You should see an App Service welcome page. If you see an error page, wait a few minutes and try again.

You can also attempt to access the App Service hostname directly. The hostname is also emitted as an output from the deployment - the output is named `appServiceHostName`. You should see a _Forbidden_ error, since your App Service instance no longer accepts requests that come from the internet.

## Notes

- Front Door Standard/Premium is currently in preview.
- When using Private Link origins with Front Door Premium during the preview period, [there is a limited set of regions available for use](https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/concept-private-link#limitations). These have been enforced in the template. Once the service is generally available this restriction will likely be removed.
- Front Door Standard/Premium is not currently available in the US Government regions.


## Results

![Deploying the Bicep](images/2021-09-20-09-47-45.png)

![Select connection to approve](images/2021-09-20-09-35-29.png)

![Approve connection](images/2021-09-20-09-44-17.png)
> Oops I forgot to add a description :)

![Connection Approved](images/2021-09-20-09-51-31.png)

Go to Private Link Center | Active connections:

![Active Connections](images/2021-09-20-09-52-10.png)

Go to the AppService link (https://azfdprivlink-dev-meyaxwasizpp6.azurewebsites.net/) -> You will get Error 403 Forbidden

![AppService link forbidden](images/2021-09-20-09-54-00.png)

App Service -> Networking tab -> Private Endpoitns is **On**:

![Private Endpoints is On](images/2021-09-20-09-55-17.png)

Goto Frontdoor in your Resource Group
![](images/2021-09-20-09-58-58.png)

Goto FrontDoor -> Endpoint Manager -> Copy Link (https://azfdprivlink-dev-meyaxwasizpp6.z01.azurefd.net):

![Copy link for app behind frontdoor](images/2021-09-20-10-10-41.png)

Open Link:

![](images/2021-09-20-10-08-54.png)

BOOM!
