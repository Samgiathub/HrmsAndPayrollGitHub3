using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0065EmpChildranDetailApp
{
    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int RowId { get; set; }

    public int CmpId { get; set; }

    public string Name { get; set; } = null!;

    public string Gender { get; set; } = null!;

    public DateTime? DateOfBirth { get; set; }

    public decimal? CAge { get; set; }

    public string? Relationship { get; set; }

    public decimal? IsResi { get; set; }

    public byte? IsDependant { get; set; }

    public string? ImagePath { get; set; }

    public string? PanCardNo { get; set; }

    public string? AdharCardNo { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public virtual T0060EmpMasterApp EmpTran { get; set; } = null!;
}
