using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class CanteenDatum
{
    public double? IoTranId { get; set; }

    public double? CmpId { get; set; }

    public double? EnrollNo { get; set; }

    public DateTime? IoDateTime { get; set; }

    public string? IpAddress { get; set; }

    public double? InOutFlag { get; set; }

    public string? IsVerify { get; set; }
}
