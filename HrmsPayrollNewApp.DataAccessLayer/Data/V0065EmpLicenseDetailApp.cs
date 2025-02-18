using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0065EmpLicenseDetailApp
{
    public string LicName { get; set; } = null!;

    public int RowId { get; set; }

    public int CmpId { get; set; }

    public int LicId { get; set; }

    public DateTime LicStDate { get; set; }

    public string? LicEndDate { get; set; }

    public string LicComments { get; set; } = null!;

    public string? LicFor { get; set; }

    public string? LicNumber { get; set; }

    public byte IsExpired { get; set; }

    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }
}
