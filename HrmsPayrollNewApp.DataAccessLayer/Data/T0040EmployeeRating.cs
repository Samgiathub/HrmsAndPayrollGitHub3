using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040EmployeeRating
{
    public decimal ERateId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? ERateFromLimit { get; set; }

    public decimal? ERateToLimit { get; set; }

    public decimal? ERank { get; set; }

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
