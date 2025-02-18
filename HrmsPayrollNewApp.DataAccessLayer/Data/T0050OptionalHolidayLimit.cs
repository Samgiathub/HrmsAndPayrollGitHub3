using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050OptionalHolidayLimit
{
    public decimal TranId { get; set; }

    public decimal HdayId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BranchId { get; set; }

    public decimal MaxLimit { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal UserId { get; set; }

    public virtual T0030BranchMaster Branch { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040HolidayMaster Hday { get; set; } = null!;
}
