using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace Escc.EastSussexGovUK.AzureDeployment
{
    class Program
    {
        static void Main(string[] args)
        {
            var configFile = new XmlDocument();
            configFile.Load(args[0]);
            var nodes = configFile.SelectNodes("/configuration/Escc.EastSussexGovUK.AzureDeployment/add");
            if (nodes != null)
            {
                foreach (XmlElement configuredTransform in nodes)
                {
                    var nodeToTransform = configFile.SelectSingleNode(configuredTransform.GetAttribute("key"));
                    if (nodeToTransform != null)
                    {
                        nodeToTransform.Value = Environment.GetEnvironmentVariable(configuredTransform.GetAttribute("value"));
                    }
                }
            }

            configFile.Save(args[0]);
        }
    }
}
