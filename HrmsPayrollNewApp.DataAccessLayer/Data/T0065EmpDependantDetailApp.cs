using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0065EmpDependantDetailApp
{
    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int RowId { get; set; }

    public int CmpId { get; set; }

    public string Name { get; set; } = null!;

    public string RelationShip { get; set; } = null!;

    public DateTime? BirthDate { get; set; }

    public decimal? DAge { get; set; }

    public string? Address { get; set; }

    public decimal? Share { get; set; }

    public decimal? IsResi { get; set; }

    public string? NomineeFor { get; set; }

    public string? PanCardNo { get; set; }

    public string? AdharCardNo { get; set; }

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public virtual T0060EmpMasterApp EmpTran { get; set; } = null!;
}
