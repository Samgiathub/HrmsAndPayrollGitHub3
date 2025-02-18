using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040RangeGetDeptGrd
{
    public decimal? RangePid { get; set; }

    public int? RangeType { get; set; }

    public decimal? CmpId { get; set; }

    public string? RangeGrade { get; set; }

    public string? RangeDept { get; set; }

    public string? GradeName { get; set; }

    public string? DeptName { get; set; }

    public DateTime? EffectiveDate { get; set; }
}
