using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999DeviceInoutDetailBack
{
    public decimal IoTranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal EnrollNo { get; set; }

    public DateTime IoDateTime { get; set; }

    public string? IpAddress { get; set; }

    public string? InOutFlag { get; set; }

    public int? IsVerify { get; set; }
}
