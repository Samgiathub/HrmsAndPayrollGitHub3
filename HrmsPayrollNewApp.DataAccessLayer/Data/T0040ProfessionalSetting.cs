using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040ProfessionalSetting
{
    public decimal CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal RowId { get; set; }

    public decimal FromLimit { get; set; }

    public decimal ToLimit { get; set; }

    public decimal Amount { get; set; }

    public string ApplicablePtMaleFemale { get; set; } = null!;

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
