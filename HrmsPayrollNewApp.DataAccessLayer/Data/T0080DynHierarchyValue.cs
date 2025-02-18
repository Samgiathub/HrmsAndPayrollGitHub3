using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080DynHierarchyValue
{
    public decimal DynHierarchyId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public string? DynHierColName { get; set; }

    public decimal? DynHierColValue { get; set; }

    public decimal? DynHierColId { get; set; }

    public decimal? IncrementId { get; set; }
}
