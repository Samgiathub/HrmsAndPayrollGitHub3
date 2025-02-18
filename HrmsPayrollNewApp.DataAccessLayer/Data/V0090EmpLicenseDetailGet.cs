using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpLicenseDetailGet
{
    public string LicName { get; set; } = null!;

    public decimal RowId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LicId { get; set; }

    public DateTime LicStDate { get; set; }

    public string? LicEndDate { get; set; }

    public string LicComments { get; set; } = null!;

    public string? LicFor { get; set; }

    public string? LicNumber { get; set; }

    public byte IsExpired { get; set; }
}
