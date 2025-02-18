using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999EmployeeEnrollment
{
    public decimal IoTranId { get; set; }

    public decimal BranchId { get; set; }

    public decimal EnrollNo { get; set; }

    public string UserName { get; set; } = null!;

    public string Lfpdata { get; set; } = null!;

    public string Lfpno { get; set; } = null!;

    public string Rfpdata { get; set; } = null!;

    public string Rfpno { get; set; } = null!;

    public byte[]? Lfiso { get; set; }

    public byte[]? Rfiso { get; set; }
}
