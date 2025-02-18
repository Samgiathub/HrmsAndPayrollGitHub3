using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050HrmsRangeDeptAllocation
{
    public decimal RangeDeptId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? RangeId { get; set; }

    public int? RangeType { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? PercentAllocate { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0040DepartmentMaster? Dept { get; set; }
}
