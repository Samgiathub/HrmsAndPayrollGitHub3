using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999DeviceEmpInformation
{
    public decimal DataTranId { get; set; }

    public string IpAddress { get; set; } = null!;

    public decimal EnrollNo { get; set; }

    public decimal FingerId { get; set; }

    public byte[] FingerTemplate { get; set; } = null!;

    public string Pwd { get; set; } = null!;

    public decimal Priviledge { get; set; }

    public string Name { get; set; } = null!;
}
