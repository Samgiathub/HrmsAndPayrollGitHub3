using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpLicenseDetail
{
    public decimal RowId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LicId { get; set; }

    public DateTime LicStDate { get; set; }

    public DateTime LicEndDate { get; set; }

    public string LicComments { get; set; } = null!;

    public string? LicFor { get; set; }

    public string? LicNumber { get; set; }

    public byte IsExpired { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040LicenseMaster Lic { get; set; } = null!;
}
