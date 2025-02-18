namespace HrmsPayrollNewApp.CommonLayer.ViewModels
{
    public class ResponseViewModel
    {
        public bool status { get; set; }
        public int code { get; set; }
        public string? message { get; set; }
        public dynamic? data { get; set; }
    }
}
