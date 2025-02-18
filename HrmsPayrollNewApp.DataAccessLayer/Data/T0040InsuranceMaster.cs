using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040InsuranceMaster
{
    public decimal InsTranId { get; set; }

    public decimal CmpId { get; set; }

    public string InsName { get; set; } = null!;

    public string? InsDesc { get; set; }

    public string Type { get; set; } = null!;

    public string? DefaultValue { get; set; }

    public int? InsuranceType { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0090EmpInsuranceDetail> T0090EmpInsuranceDetails { get; set; } = new List<T0090EmpInsuranceDetail>();
}
