using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;

namespace BobLogin
{
    class Program
    {
        private const string username = "username";
        private const string password = "password";

        static void Main(string[] args)
        {
            var client = getAuthenticatedClient();
            var content = client.DownloadString("https://moj.bob.si/racuni-in-poraba/stevec-porabe");
            string table = content.Substring(content.IndexOf("<table id=\"usageCounter"));
            table = table.Substring(0, table.IndexOf("</table"));
            Console.WriteLine(table);
        }

        private static WebClientEx getAuthenticatedClient()
        {
            using (var client = new WebClientEx())
            {
                // get cookie and hidden inputs
                var content = client.DownloadString("https://moj.bob.si/");

                //parse inputs and post login data
                var values = new NameValueCollection();
                values.Add("UserName", username);
                values.Add("Password", password);
                values.Add("IsSamlLogin", "False");
                values.Add("InternalBackUrl", "");
                values.Add("IsPopUp", "True");
                values.Add("__RequestVerificationToken", getHiddenInput(content, "__RequestVerificationToken"));
                client.UploadValues("https://prijava.bob.si/SSO/Login/Login", "POST", values);

                //get additional hidden inputs
                content = client.DownloadString("https://moj.bob.si/");

                //parse inputs and post additional data
                values = new NameValueCollection();
                values.Add("authTicket", getHiddenInput(content, "authTicket"));
                values.Add("subscriberService", getHiddenInput(content, "subscriberService"));
                client.UploadValues("https://moj.bob.si/ssologin/login?returnUrl=/", values);

                return client;
            }
        }

        private static string getHiddenInput(string content, string inputName)
        {
            string input = content.Substring(content.IndexOf(inputName));
            input = input.Substring(input.IndexOf("value") + 7);
            input = input.Substring(0, input.IndexOf("\""));

            return input;
        }
    }

    /// <summary>
    /// A custom WebClient featuring a cookie container
    /// </summary>
    public class WebClientEx : WebClient
    {
        public CookieContainer CookieContainer { get; private set; }

        public WebClientEx()
        {
            CookieContainer = new CookieContainer();
        }

        protected override WebRequest GetWebRequest(Uri address)
        {
            var request = base.GetWebRequest(address);
            if (request is HttpWebRequest)
            {
                (request as HttpWebRequest).CookieContainer = CookieContainer;
            }
            return request;
        }
    }
}