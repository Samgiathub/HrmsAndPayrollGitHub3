using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999DeviceInoutDetail1
{
    public decimal IoTranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal EnrollNo { get; set; }

    public DateTime IoDateTime { get; set; }

    public string? IpAddress { get; set; }

    public string? InOutFlag { get; set; }
}
