using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040LicenseMaster
{
    public decimal LicId { get; set; }

    public decimal CmpId { get; set; }

    public string LicName { get; set; } = null!;

    public string LicComments { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0090EmpLicenseDetail> T0090EmpLicenseDetails { get; set; } = new List<T0090EmpLicenseDetail>();
}
