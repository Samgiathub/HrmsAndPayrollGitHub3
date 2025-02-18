using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0015LoginRight
{
    public decimal LoginRightsId { get; set; }

    public decimal LoginTypeId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LoginId { get; set; }

    public decimal IsSave { get; set; }

    public decimal IsEdit { get; set; }

    public decimal IsDelete { get; set; }

    public decimal IsReport { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0011Login Login { get; set; } = null!;

    public virtual T0001LoginType LoginType { get; set; } = null!;
}
