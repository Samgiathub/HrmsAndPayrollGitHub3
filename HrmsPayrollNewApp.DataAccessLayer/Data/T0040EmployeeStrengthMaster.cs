using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040EmployeeStrengthMaster
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? Strength { get; set; }

    public string? Flag { get; set; }

    public decimal? CatId { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDatetime { get; set; }
}
