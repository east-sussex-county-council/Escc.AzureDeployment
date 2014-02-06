using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Xml;
using System.Xml.XPath;

namespace Escc.EastSussexGovUK.AzureDeployment.ConfigTransform
{
    /// <summary>
    /// Transform a web.config using environment variables
    /// </summary>
    class Program
    {
        
        /// <summary>
        /// Defines the entry point of the application.
        /// </summary>
        /// <param name="args">The arguments.</param>
        static void Main(string[] args)
        {
            // Validate arguments. If no output file specified, default to input file.
            if (args.Length == 1) args = new string[] { args[0], args[0] };
            if (args.Length != 2 || !File.Exists(args[0]))
            {
                ShowHelp();
                return;
            }

            var configFile = new XmlDocument();
            try
            {
                configFile.Load(args[0]);
            }
            catch (XmlException)
            {
                Console.WriteLine(String.Format(CultureInfo.CurrentCulture, Properties.Resources.InputFileIsNotValidXML, args[0]));
                return;
            }

            // Read XPath expressions and corresponding environment variable names from config section. 
            // Use XPath to look up an element or an attribute, and replace its value with the value of the environment variable.
            var transforms = configFile.SelectNodes("/configuration/Escc.EastSussexGovUK.AzureDeployment.ConfigTransforms/add");
            if (transforms != null)
            {
                TransformNodes(transforms, configFile);
            }

            configFile.Save(args[1]);
        }

        /// <summary>
        /// Applies the configured transforms
        /// </summary>
        /// <param name="transforms">The transforms.</param>
        /// <param name="configFile">The configuration file.</param>
        private static void TransformNodes(XmlNodeList transforms, XmlDocument configFile)
        {
            foreach (XmlElement configuredTransform in transforms)
            {
                try
                {
                    TransformNode(configuredTransform, configFile);
                }
                catch (XPathException)
                {
                    Console.WriteLine(String.Format(CultureInfo.CurrentCulture, Escc.EastSussexGovUK.AzureDeployment.ConfigTransform.Properties.Resources.XPathIsInvalid, configuredTransform.GetAttribute("key")));
                }
            }
        }

        /// <summary>
        /// Finds the node referenced by the XPath expression and replaces its value with an environment variable
        /// </summary>
        /// <param name="configuredTransform">The configured transform.</param>
        /// <param name="configFile">The configuration file.</param>
        private static void TransformNode(XmlElement configuredTransform, XmlDocument configFile)
        {
            // Start with context of /configuration/ to save typing it every time
            var nodeToTransform = configFile.SelectSingleNode("/configuration/" + configuredTransform.GetAttribute("key"));
            if (nodeToTransform != null)
            {
                var element = nodeToTransform as XmlElement;
                if (element != null)
                {
                    element.InnerXml = Environment.GetEnvironmentVariable(configuredTransform.GetAttribute("value"));
                }
                else if (nodeToTransform is XmlAttribute)
                {
                    nodeToTransform.Value = Environment.GetEnvironmentVariable(configuredTransform.GetAttribute("value"));
                }
            }
        }

        private static void ShowHelp()
        {
            Console.WriteLine();
            Console.WriteLine(Properties.Resources.Usage);
            Console.WriteLine();
        }
    }
}
