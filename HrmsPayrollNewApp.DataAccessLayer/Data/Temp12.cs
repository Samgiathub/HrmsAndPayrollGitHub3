using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class Temp12
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal SchemeId { get; set; }

    public string Type { get; set; } = null!;

    public DateTime EffectiveDate { get; set; }

    public bool? IsMakerChecker { get; set; }

    public decimal? RptLevel { get; set; }

    public decimal? DynHierId { get; set; }

    public string? TravelTypeId { get; set; }

    public decimal DynHierarchyId { get; set; }

    public string? DynHierColName { get; set; }

    public decimal? DynHierColValue { get; set; }

    public decimal? DynHierColId { get; set; }

    public decimal? IncrementId { get; set; }

    public decimal? AppId { get; set; }
}
