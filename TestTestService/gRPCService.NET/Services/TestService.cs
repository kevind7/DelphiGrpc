using System.Threading.Tasks;
using Google.Protobuf.WellKnownTypes;
using Grpc.Core;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Collections.Generic;


namespace gRPCService.NET
{
    public class TestServiceService : TestService.TestServiceBase
    {
        private readonly ILogger<TestServiceService> _logger;
        private readonly char[] Chars = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b',
            'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'o', 'p', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
            'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
        private readonly string c_OK = "[OK]";
        private readonly string c_Failure = "[Failure]";
        private readonly byte[] c_SaveSimpleTestByteArray = { 17, 25, 48, 8, 178 };
        private readonly byte[] c_DoubleSimpleTestByteArray = { 99, 45, 17, 22, 55 };
        private readonly byte[] c_EmbeddedMessageSimpleByteArray = { 0, 100, 90, 190, 150 };
        private readonly byte[] c_EmbeddedMessageComplexByteArray = { 33, 32, 13, 21, 45, 1, 52, 51, 6, 1 };
        private readonly byte[] c_EmbeddedMessageComplexByteArray02 = { 55,44,66,77,88,99 };
        private readonly string[] c_EmbeddedMessageStringArray = { "You got a fast car", "I want a ticket to anywhere", 
            "Maybe we make a deal", "Maybe together we can get somewhere",
        "Any place is better", "Starting from zero got nothing to lose", "Maybe well make something",
        "Me, myself, I got nothing to prove"};

        public TestServiceService(ILogger<TestServiceService> logger)
        {
            _logger = logger;
        }

        public override Task<AllTypes> CheckAllTypes(Google.Protobuf.WellKnownTypes.Empty request, ServerCallContext context)
        {
            /*
             	double DoubleData = 1;
	            float FloatData = 2;
	            int32 UInt32Data = 3;
	            int64 UInt64Data = 4;
	            sint32 Int32Data = 5;
	            sint64 Int64Data = 6;
	            bool BoolData = 7;
	            string UTF8StringData = 8;
	            bytes ArrayOfByteData = 9;
	            EnumType EnumData = 10;
            */
            byte[] vBytes = new byte[10];
            for (int i = 0; i < 10; i++)
                vBytes[i] = (byte)((i + 1) * 9);
            AllTypes vTypes = new AllTypes { DoubleData = 0.32141516f, FloatData = 0.451419f, UInt32Data = 343311, 
                UInt64Data = 9147568, Int32Data = -4512, Int64Data = -914175866, BoolData = false, UTF8StringData = "TryingThisNewCoolFramework",
                ArrayOfByteData = Google.Protobuf.ByteString.CopyFrom(vBytes), EnumData = EnumType.One};
            return Task.FromResult(vTypes);
        }

        public override Task<Simple> OneSimple(Empty request, ServerCallContext context)
        {
            byte[] vBytes = new byte[5];
            vBytes[0] = 14;
            vBytes[1] = 98;
            vBytes[2] = 123;
            vBytes[3] = 11;
            vBytes[4] = 4;
            return Task.FromResult(new Simple { Name = "Steven Benz", ID = 14, Info = Google.Protobuf.ByteString.CopyFrom(vBytes)});
        }

        public override Task<Simple> DoubleSimple(Simple request, ServerCallContext context)
        {
            String vResult = "";
            int i = 0;
            vResult = request.Name == "Thelonious Monk" ? c_OK : c_Failure;
            Console.WriteLine("Name: {0} should be Thelonious Monk {1}", request.Name, vResult);
            vResult = request.ID == 37 ? c_OK : c_Failure;
            Console.WriteLine("ID: {0} should be 37 {1}", request.ID, vResult);
            var vInfo = request.Info.ToByteArray();
            String vInfoStr = "";
            for (i = 0; i < vInfo.Length; i++)
            {
                vResult = c_OK;
                if (vInfo[i] != c_DoubleSimpleTestByteArray[i])
                {
                    vResult = c_Failure;
                    break;
                }
            }
            for (i = 0; i < vInfo.Length; i++)
                vInfoStr = vInfoStr + vInfo[i].ToString() + " ";
            Console.WriteLine("Info: {0} should be 99 45 17 22 55 {1}", vInfoStr, vResult);
            byte[] vBytes = new byte[5];
            vBytes[0] = 77;
            vBytes[1] = 89;
            vBytes[2] = 5;
            vBytes[3] = 19;
            vBytes[4] = 33;
            return Task.FromResult(new Simple { Name = "Wes Montgomery", ID = 41, Info = Google.Protobuf.ByteString.CopyFrom(vBytes) });
        }

        public override Task<Empty> SaveSimple(Simple request, ServerCallContext context)
        {
            String vResult = "";
            int i = 0;
            vResult = request.Name == "Joe Pass" ? c_OK : c_Failure;
            Console.WriteLine("Name: {0} should be Joe Pass {1}", request.Name, vResult);
            if (vResult == c_Failure)
                throw new RpcException(new Status(StatusCode.InvalidArgument, "Invalid argument"));
            vResult = request.ID == 97 ? c_OK : c_Failure;
            Console.WriteLine("ID: {0} should be 97 {1}", request.ID, vResult);
            if (vResult == c_Failure)
                throw new RpcException(new Status(StatusCode.InvalidArgument, "Invalid argument"));
            var vInfo = request.Info.ToByteArray();
            String vInfoStr = "";
            for (i = 0; i < vInfo.Length; i++)
            {
                vResult = c_OK;
                if (vInfo[i] != c_SaveSimpleTestByteArray[i])
                {
                    vResult = c_Failure;
                    break;
                }
            } 
            for (i = 0; i < vInfo.Length; i++)
                vInfoStr = vInfoStr + vInfo[i].ToString() + " ";
            Console.WriteLine("Info: {0} should be 17 25 48 8 178 {1}", vInfoStr, vResult);
            if (vResult == c_Failure)
               throw new RpcException(new Status(StatusCode.InvalidArgument, "Invalid argument"));
            return Task.FromResult(new Empty { });
        }

        public override Task<RepAllTypes> RepSimple(RepAllTypes request, ServerCallContext context)
        {
            /*
                repeated double DoubleData = 1;
                repeated float FloatData = 2;
                repeated fixed32 UInt32Data = 3;
                repeated fixed64 UInt64Data = 4;
                repeated sfixed32 Int32Data = 5;
                repeated sfixed64 Int64Data = 6;
                repeated bool BoolData = 7;
                repeated string UTF8StringData = 8;
                repeated bytes ArrayOfByteData = 9;
                repeated EnumType EnumData = 10;
            */
            string vDataArray = "";
            int i = 0;

            for (i = 0; i < request.DoubleData.Count; i++)
                vDataArray = vDataArray + request.DoubleData[i].ToString() + " ";
            Console.WriteLine("Count is {0}", request.DoubleData.Count);
            Console.WriteLine("DoubleDataArray is {0}", vDataArray);
            Console.WriteLine("");
            vDataArray = "";

            for (i = 0; i < request.FloatData.Count; i++)
                vDataArray = vDataArray + request.FloatData[i].ToString() + " ";
            Console.WriteLine("Count is {0}", request.FloatData.Count);
            Console.WriteLine("FloatDataArray is {0}", vDataArray);
            Console.WriteLine("");
            vDataArray = "";

            for (i = 0; i < request.UInt32Data.Count; i++)
                vDataArray = vDataArray + request.UInt32Data[i].ToString() + " ";
            Console.WriteLine("Count is {0}", request.UInt32Data.Count);
            Console.WriteLine("UInt32DataArray is {0}", vDataArray);
            Console.WriteLine("");
            vDataArray = "";

            for (i = 0; i < request.UInt64Data.Count; i++)
                vDataArray = vDataArray + request.UInt64Data[i].ToString() + " ";
            Console.WriteLine("Count is {0}", request.UInt64Data.Count);
            Console.WriteLine("UInt64DataArray is {0}", vDataArray);
            Console.WriteLine("");
            vDataArray = "";

            for (i = 0; i < request.Int32Data.Count; i++)
                vDataArray = vDataArray + request.Int32Data[i].ToString() + " ";
            Console.WriteLine("Count is {0}", request.Int32Data.Count);
            Console.WriteLine("Int32DataArray is {0}", vDataArray);
            Console.WriteLine("");
            vDataArray = "";

            for (i = 0; i < request.Int64Data.Count; i++)
                vDataArray = vDataArray + request.Int64Data[i].ToString() + " ";
            Console.WriteLine("Count is {0}", request.Int64Data.Count);
            Console.WriteLine("Int64DataArray is {0}", vDataArray);
            Console.WriteLine("");
            vDataArray = "";

            for (i = 0; i < request.BoolData.Count; i++)
                vDataArray = vDataArray + request.BoolData[i].ToString() + " ";
            Console.WriteLine("Count is {0}", request.BoolData.Count);
            Console.WriteLine("BoolDataArray is {0}", vDataArray);
            Console.WriteLine("");
            vDataArray = "";

            for (i = 0; i < request.UTF8StringData.Count; i++)
                vDataArray = vDataArray + request.UTF8StringData[i].ToString() + "\n";
            Console.WriteLine("Count is {0}", request.UTF8StringData.Count);
            Console.WriteLine("UTF8StringDataArray is {0}", vDataArray);
            Console.WriteLine("");
            vDataArray = "";

            for (i = 0; i < request.EnumData.Count; i++)
                vDataArray = vDataArray + request.EnumData[i].ToString() + " ";
            Console.WriteLine("Count is {0}", request.EnumData.Count);
            Console.WriteLine("EnumDataArray is {0}", vDataArray);
            Console.WriteLine("");
            vDataArray = "";

            double[] DoubleDataArray = { 0.12131415f, 0.222324f, 0.323334f, 0.424344f, 0.525354f };
            float[] FloatDataArray = { 0.121314f, 0.222324f, 0.323334f, 0.424344f, 0.525354f };
            UInt32[] UInt32DataArray = { 4500, 6000, 156712, 7891234, 140456781 , 1 , 88, 97, 145, 2002};
            UInt64[] UInt64DataArray = { 9922, 18455, 9812, 147987, 28043286701 , 4, 99, 3920, 32567, 77};
            Int32[] Int32DataArray = { -1, -5000, -2147, -4294, 9000, 18000, 54000, 885, 607, 761111 };
            Int64[] Int64DataArray = { -3283823891, -4, -1992, -8956895, 88884, 99901, 4, 99, 7};
            bool[] BoolDataArray = { true, true, true, false, false, true, false, false, false, true };
            string[] UTF8StringDataArray = { "Well, shes walking through the clouds", 
                "With a circus mind" , "Thats running wild" , 
                "Butterflies and zebras and moonbeams", "And fairly tales", 
                "Thats all she ever thinks about", "Riding the wind"};
            EnumType[] EnumTypeArray = { EnumType.One, EnumType.Three, EnumType.Two, EnumType.Two, EnumType.One };
            RepAllTypes vRepAllTypes = new RepAllTypes();

            vRepAllTypes.DoubleData.Add(DoubleDataArray);
            vRepAllTypes.FloatData.Add(FloatDataArray);
            vRepAllTypes.UInt32Data.Add(UInt32DataArray);
            vRepAllTypes.UInt64Data.Add(UInt64DataArray);
            vRepAllTypes.Int32Data.Add(Int32DataArray);
            vRepAllTypes.Int64Data.Add(Int64DataArray);
            vRepAllTypes.BoolData.Add(BoolDataArray);
            vRepAllTypes.UTF8StringData.Add(UTF8StringDataArray);
            vRepAllTypes.EnumData.Add(EnumTypeArray);

            return Task.FromResult(vRepAllTypes);
        }

        public override Task<EmbeddedSimple> EmbeddedMessageSimple(EmbeddedSimple request, ServerCallContext context)
        {
            string vResult = "";
            string vByteString = "";
            string vStreamInfoString = "";
            int i;

            vResult = request.TypeName == "EmbeddedSimple" ? c_OK : c_Failure;
            Console.WriteLine("TypeName: {0} should be EmbeddedSimple {1}", request.TypeName, vResult);
            vResult = request.SimpleData.Name == "Chick Corea" ? c_OK : c_Failure;
            Console.WriteLine("SimpleData.Name: {0} should be Chick Corea {1}", request.SimpleData.Name, vResult);
            vResult = request.SimpleData.ID == 177 ? c_OK : c_Failure;
            Console.WriteLine("SimpleData.ID: {0} should be 177 {1}", request.SimpleData.ID, vResult);
            vResult = c_OK;
            for (i = 0; i < request.SimpleData.Info.Length; i++)
            {
                vByteString = vByteString + c_EmbeddedMessageSimpleByteArray[i].ToString() + " ";
                if (request.SimpleData.Info[i] != c_EmbeddedMessageSimpleByteArray[i])
                {
                    vResult = c_Failure;
                    break;
                }
            }
            Console.WriteLine("SimpleData.Info: {0} should be 0 100 90 190 150 {1}", vByteString, vResult);

            vResult = c_OK;
            for (i = 0; i < request.StreamInfoArray.Count; i++)
            {
                vStreamInfoString = vStreamInfoString + c_EmbeddedMessageStringArray[i] + "\n";
                if (request.StreamInfoArray[i].Info != c_EmbeddedMessageStringArray[i])
                {
                    vResult = c_Failure;
                    break;
                }
            }            
            Console.WriteLine("StreamInfoArray.Info: {0} is", vStreamInfoString, vResult);

            byte[] vBytes = new byte[5];
            vBytes[0] = 55;
            vBytes[1] = 123;
            vBytes[2] = 59;
            vBytes[3] = 11;
            vBytes[4] = 49;
            EmbeddedSimple vEmbSimple = new EmbeddedSimple { TypeName = "EmbeddedSimple", 
                SimpleData = new Simple { ID = 19, Name = "Al Di Meola", Info = Google.Protobuf.ByteString.CopyFrom(vBytes)}};
            StreamInfo[] vStreamInfoArray = new StreamInfo[5];
            vStreamInfoArray[0] = new StreamInfo { Info = "StreamOne" };
            vStreamInfoArray[1] = new StreamInfo { Info = "StreamTwo" };
            vStreamInfoArray[2] = new StreamInfo { Info = "StreamThree" };
            vStreamInfoArray[3] = new StreamInfo { Info = "StreamFour" };
            vStreamInfoArray[4] = new StreamInfo { Info = "StreamFive" };
            vEmbSimple.StreamInfoArray.Add(vStreamInfoArray);
            return Task.FromResult(vEmbSimple);
        }

        public override Task<EmbeddedComplex> EmbeddedMessageComplex(EmbeddedComplex request, ServerCallContext context)
        {
            int i;
            string vResult = "";
            string vByteString = "";

            vResult = request.ComplexInfo == "Eric Johnson" ? c_OK : c_Failure;
            Console.WriteLine("ComplexInfo: {0} should be Eric Johnson {1}", request.ComplexInfo, vResult);

            vResult = c_OK;
            for (i = 0; i < request.ComplexData.RawData.Length; i++)
            {
                vByteString = vByteString + c_EmbeddedMessageComplexByteArray[i].ToString() + " ";
                if (request.ComplexData.RawData[i] != c_EmbeddedMessageComplexByteArray[i])
                {
                    vResult = c_Failure;
                    break;
                }

            }
            Console.WriteLine("ComplexData.RawData: {0} is {1}", vByteString, vResult);

            vResult = request.ComplexData.DataInfo == "Cliffs of Dover" ? c_OK : c_Failure;
            Console.WriteLine("ComplexData.DataInfo: {0} should be Cliffs of Dover {1}", request.ComplexData.DataInfo, vResult);

            vResult = request.ComplexData.DataID == 10 ? c_OK : c_Failure;
            Console.WriteLine("ComplexData.DataID: {0} should be 10 {1}", request.ComplexData.DataID, vResult);

            vResult = request.ComplexData.SimpleData.Name == "Steve Vai" ? c_OK : c_Failure;
            Console.WriteLine("ComplexData.DataInfo: {0} should be Steve Vai {1}", request.ComplexData.SimpleData.Name, vResult);

            vResult = request.ComplexData.SimpleData.ID == 44 ? c_OK : c_Failure;
            Console.WriteLine("ComplexData.SimpleData.ID: {0} should be 44 {1}", request.ComplexData.DataInfo, vResult);

            vByteString = "";
            vResult = c_OK;
            for (i = 0; i < request.ComplexData.SimpleData.Info.Length; i++)
            {
                vByteString = vByteString + c_EmbeddedMessageComplexByteArray02[i].ToString() + " ";
                if (request.ComplexData.SimpleData.Info[i] != c_EmbeddedMessageComplexByteArray02[i])
                {
                    vResult = c_Failure;
                    break;
                }

            }
            Console.WriteLine("ComplexData.SimpleData.Info: {0} is {1}", vByteString, vResult);


            EmbeddedComplex vEmbComplex = new EmbeddedComplex();
            vEmbComplex.ComplexInfo = "Caspar Wessel";
            vEmbComplex.ComplexData = new ComplexStruct();
            byte[] vBytes = new byte[8];
            vBytes[0] = 122;
            vBytes[1] = 199;
            vBytes[2] = 71;
            vBytes[3] = 18;
            vBytes[4] = 88;
            vBytes[5] = 91;
            vBytes[6] = 7;
            vBytes[7] = 156;
            vEmbComplex.ComplexData.RawData = Google.Protobuf.ByteString.CopyFrom(vBytes);
            vEmbComplex.ComplexData.DataInfo = "jtv84hny9ptgy9gmvya987ntypav4fgya8n";
            vEmbComplex.ComplexData.DataID = 1855;

            byte[] vSimpleBytes = new byte[10];
            vSimpleBytes[0] = 11; vSimpleBytes[1] = 20; vSimpleBytes[2] = 29; vSimpleBytes[3] = 44; vSimpleBytes[4] = 85;
            vSimpleBytes[5] = 68; vSimpleBytes[6] = 54; vSimpleBytes[7] = 15; vSimpleBytes[8] = 66; vSimpleBytes[9] = 120;
            vEmbComplex.ComplexData.SimpleData = new Simple { Name = "Jean-Baptiste Joseph Fourier", ID = 81, Info = Google.Protobuf.ByteString.CopyFrom(vSimpleBytes) };
            return Task.FromResult(vEmbComplex);
        }

        public override Task<Any> ReturnAnyType(InfoString request, ServerCallContext context)
        {
            Any vPack = null;
            switch (request.Info)
            {
                case "type.googleapis.com/TestService.AllTypes":
                    byte[] vBytes = new byte[10];
                    for (int i = 0; i < 10; i++)
                        vBytes[i] = (byte)((i + 1) * 9);
                    AllTypes vTypes = new AllTypes
                    {
                        DoubleData = 0.32141516f,
                        FloatData = 0.451419f,
                        UInt32Data = 343311,
                        UInt64Data = 9147568,
                        Int32Data = -4512,
                        Int64Data = -914175866,
                        BoolData = false,
                        UTF8StringData = "TryingThisNewCoolFramework",
                        ArrayOfByteData = Google.Protobuf.ByteString.CopyFrom(vBytes),
                        EnumData = EnumType.Two
                    };
                    vPack = Any.Pack(vTypes);
                    break;

                case "type.googleapis.com/TestService.Simple":
                    byte[] vData = { 33, 48, 99, 222};
                    var vSimple = new Simple { ID = 46578, Name = "Stan Getz", Info = Google.Protobuf.ByteString.CopyFrom(vData) };
                    vPack = Any.Pack(vSimple);
                    break;

                case "type.googleapis.com/TestService.RepAllTypes":
                    double[] DoubleDataArray = { 0.413231f, 0.183473f, 0.318392f, 0.323232f, 0.11147f };
                    float[] FloatDataArray = { 0.414342f, 0.444561f, 0.1028367f, 0.51782f, 0.88723f };
                    UInt32[] UInt32DataArray = { 45689, 2, 5555, 7534, 1564, 78524, 24351, 764898, 156456, 96965 };
                    UInt64[] UInt64DataArray = { 46468, 41325151, 8885624343, 123232424241, 3424245252, 7, 77, 777, 7777, 77777 };
                    Int32[] Int32DataArray = { -1, -9999, -4467, -14891, 4744, 14700, 29400, -885, 11607, 99761111 };
                    Int64[] Int64DataArray = { -32891, -41, -12, -8895, 84, 901, 4, 9, 1};
                    bool[] BoolDataArray = { false, true, false, false, false, true, false, false, false, true };
                    string[] UTF8StringDataArray = { "Confutatis maledictis",
                        "flammis acribus addictis" , "voca me cum benedictis" ,
                        "Oro supplex et acclinis", "cor contritum quasi cinis",
                        "gere curam", "mei finis"};
                    EnumType[] EnumTypeArray = { EnumType.One, EnumType.Two, EnumType.Two, EnumType.Two, EnumType.Three };
                    RepAllTypes vRepAllTypes = new RepAllTypes();

                    vRepAllTypes.DoubleData.Add(DoubleDataArray);
                    vRepAllTypes.FloatData.Add(FloatDataArray);
                    vRepAllTypes.UInt32Data.Add(UInt32DataArray);
                    vRepAllTypes.UInt64Data.Add(UInt64DataArray);
                    vRepAllTypes.Int32Data.Add(Int32DataArray);
                    vRepAllTypes.Int64Data.Add(Int64DataArray);
                    vRepAllTypes.BoolData.Add(BoolDataArray);
                    vRepAllTypes.UTF8StringData.Add(UTF8StringDataArray);
                    vRepAllTypes.EnumData.Add(EnumTypeArray);
                    vPack = Any.Pack(vRepAllTypes);
                    break;
                default:
                    var vRng = new Random();
                    byte[] vSimpleBytes = new byte[40];
                    for (int i = 0; i < 40; i++)
                        vSimpleBytes[i] = (byte)vRng.Next(0, 254);
                    var vSimpleMessage = new Simple { ID = 255, Name = "DEFAULT", Info = Google.Protobuf.ByteString.CopyFrom(vSimpleBytes) };
                    vPack = Any.Pack(vSimpleMessage);
                    break;
            }
            return Task.FromResult(vPack);
        }

        public override async Task BeginStream(Empty request, IServerStreamWriter<StreamData> responseStream, ServerCallContext context)
        {            
            var vBeginStreamWriter = responseStream;
            var vBeginStreamToken = context.CancellationToken;
            var vSendBytesTask = Task.Run(() => BeginStreamSendBytes(vBeginStreamWriter, vBeginStreamToken));
            await Task.Delay(Timeout.Infinite, vBeginStreamToken);
            vSendBytesTask = null;
            Console.WriteLine("Token is {0} " + vBeginStreamToken.IsCancellationRequested);
        }

        private void BeginStreamSendBytes(IServerStreamWriter<StreamData> pStreamWriter, CancellationToken pToken)
        {
            var rng = new Random();
            while (pStreamWriter != null)
            {
                int i;
                try
                {
                    byte[] vData = new byte[40];
                    for (i = 0; i < 40; i++)
                        vData[i] = (byte)rng.Next(0, 254);
                    Int32 vDataType = rng.Next(0, 4);
                    char[] vChars = new char[32];
                    for (i = 0; i < 32; i++)
                        vChars[i] = Chars[rng.Next(0, 59)];
                    StreamData vStreamData = new StreamData { Data = Google.Protobuf.ByteString.CopyFrom(vData), DataType = vDataType, ExtraInfo = new string(vChars) };
                    Console.WriteLine("Sending token status is {0}", pToken.IsCancellationRequested);
                    pStreamWriter.WriteAsync(vStreamData).Wait();                        
                }
                catch
                {
                    Console.WriteLine("BeginStream is closed");
                    pStreamWriter = null;
                    break;
                }
                Task.Delay(TimeSpan.FromMilliseconds(500)).Wait();
            }
        }

        public override async Task BeginStreamEx(StreamInfo request, IServerStreamWriter<StreamData> responseStream, ServerCallContext context)
        {
            string vResult = "";
            vResult = request.Info == "uyb897yg9a8gy87khcv487hfgm86fghy8g4hsghy4m" ? c_OK : c_Failure;
            Console.WriteLine("StreamInfo.Info: {0} should be uyb897yg9a8gy87khcv487hfgm86fghy8g4hsghy4m {1}", request.Info, vResult);

            var vBeginStreamExWriter = responseStream;
            var vBeginStreamExToken = context.CancellationToken;
            var vSendBytesExTask = Task.Run(() => BeginStreamExSendBytes(vBeginStreamExWriter, vBeginStreamExToken));
            await Task.Delay(Timeout.Infinite, vBeginStreamExToken);
            vSendBytesExTask = null;
            Console.WriteLine("Token is {0} " + vBeginStreamExToken.IsCancellationRequested);
        }

        private void BeginStreamExSendBytes(IServerStreamWriter<StreamData> pWriter, CancellationToken pToken)
        {
            var rng = new Random();
            while (true)
            {
                int i;
                if (pWriter != null)
                    try
                    {
                        byte[] vData = new byte[40];
                        for (i = 0; i < 40; i++)
                            vData[i] = (byte)rng.Next(0, 254);
                        Int32 vDataType = rng.Next(0, 4);
                        char[] vChars = new char[32];
                        for (i = 0; i < 32; i++)
                          vChars[i] = Chars[rng.Next(0, 59)];
                        StreamData vStreamData = new StreamData { Data = Google.Protobuf.ByteString.CopyFrom(vData), DataType = vDataType, ExtraInfo = new string(vChars) };
                        pWriter.WriteAsync(vStreamData).Wait();
                    }
                    catch
                    {
                        Console.WriteLine("BeginStreamEx is closed");
                        pWriter = null;
                        break;
                    }
                Task.Delay(TimeSpan.FromMilliseconds(500)).Wait();
            }
        }

        public override async Task<Empty> ClientStream(IAsyncStreamReader<StreamData> requestStream, ServerCallContext context)
        {
            await foreach (var vUpdate in requestStream.ReadAllAsync())
            {
                Console.WriteLine("StreamData.Data are =>");
                for (int i = 0; i < vUpdate.Data.Length; i++)
                    Console.Write("{0} ", vUpdate.Data[i]);
                Console.WriteLine("");
                Console.WriteLine("StreamData.DataType: is {0}", vUpdate.DataType);
                Console.WriteLine("StreamData.ExtraInfo: is {0}", vUpdate.ExtraInfo);

            }
            return new Empty { };
        }

        public override async Task<StreamInfo> ClientStreamEx(IAsyncStreamReader<StreamData> requestStream, ServerCallContext context)
        {
            UInt32 vMessageCount = 0;
            await foreach (var vUpdate in requestStream.ReadAllAsync())
            {
                vMessageCount++;
                Console.WriteLine("StreamData.Data are =>");
                for (int i = 0; i < vUpdate.Data.Length; i++)
                    Console.Write("{0} ", vUpdate.Data[i]);
                Console.WriteLine("");
                Console.WriteLine("StreamData.DataType: is {0}", vUpdate.DataType);
                Console.WriteLine("StreamData.ExtraInfo: is {0}", vUpdate.ExtraInfo);
            }
            return new StreamInfo { Info = $"You have sent {vMessageCount - 1} through this stream" };
        }

        public override async Task DuplexStream(IAsyncStreamReader<StreamInfo> requestStream, IServerStreamWriter<StreamData> responseStream, ServerCallContext context)
        {
            var vDuplexStreamWriter = responseStream;
            var vDuplexStreamToken = context.CancellationToken;
            var SendBytesDuplexTask = Task.Run(() => DuplexStreamSendBytes(vDuplexStreamWriter));
            await foreach (var vUpdate in requestStream.ReadAllAsync())
            {
                Console.WriteLine("StreamInfo.Info: is {0}", vUpdate.Info);
            }
            await Task.Delay(Timeout.Infinite, vDuplexStreamToken);
        }
        private void DuplexStreamSendBytes(IServerStreamWriter<StreamData> pWriter)
        {
            var rng = new Random();
            while (true)
            {
                int i;
                if (pWriter != null)
                    try
                    {
                        byte[] vData = new byte[40];
                        for (i = 0; i < 40; i++)
                            vData[i] = (byte)rng.Next(0, 254);
                        Int32 vDataType = rng.Next(0, 4);
                        char[] vChars = new char[32];
                        for (i = 0; i < 32; i++)
                          vChars[i] = Chars[rng.Next(0, 59)];
                        StreamData vStreamData = new StreamData { Data = Google.Protobuf.ByteString.CopyFrom(vData), DataType = vDataType, ExtraInfo = new string(vChars) };
                        pWriter.WriteAsync(vStreamData).Wait();
                    }
                    catch
                    {
                        Console.WriteLine("DuplexStream is closed");
                        pWriter = null;
                        break;
                    }
                Task.Delay(TimeSpan.FromMilliseconds(500)).Wait();
            }
        }
    }
}