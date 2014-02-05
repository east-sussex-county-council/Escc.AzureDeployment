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
            var node = configFile.SelectSingleNode("/configuration/CustomSection/add[@key='CustomConfig']/@value");
            if (node != null)
            {
                node.Value = Environment.GetEnvironmentVariable(node.Value);
            }

            configFile.Save(args[0]);
        }
    }
}
