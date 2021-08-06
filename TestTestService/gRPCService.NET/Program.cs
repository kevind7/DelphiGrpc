using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Net;

namespace gRPCService.NET
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }

        // Additional configuration is required to successfully run gRPC on macOS.
        // For instructions on how to configure Kestrel and gRPC clients on macOS, visit https://go.microsoft.com/fwlink/?linkid=2099682
        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {

                    UInt16 vPort = 5000;
                    if (args.Length >= 1)
                        vPort = UInt16.Parse(args[0]);
                    webBuilder.UseStartup<Startup>();
                    webBuilder.UseUrls($"http://localhost:{vPort}", $"https://localhost:{vPort+1}");
                    //webBuilder.UseKestrel(opts =>
                    //{
                    //    opts.Listen(IPAddress.Loopback, port: vPort);
                    //});
                });
    }
}
