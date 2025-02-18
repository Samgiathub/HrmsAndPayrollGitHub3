using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999LicenseRequest
{
    public decimal LicReqId { get; set; }

    public string ContactPerson { get; set; } = null!;

    public string CmpName { get; set; } = null!;

    public string CmpAddress { get; set; } = null!;

    public string Location { get; set; } = null!;

    public string TelNo { get; set; } = null!;

    public string MobNo { get; set; } = null!;

    public string EmailId { get; set; } = null!;

    public decimal NoOfEmp { get; set; }

    public DateTime ReqDate { get; set; }

    public decimal OwnServer { get; set; }

    public decimal SupType { get; set; }

    public decimal ModRequire { get; set; }

    public string ModComments { get; set; } = null!;

    public string? IpAddress { get; set; }
}
