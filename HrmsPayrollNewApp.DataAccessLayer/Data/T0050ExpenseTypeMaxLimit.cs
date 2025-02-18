using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050ExpenseTypeMaxLimit
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ExpenseTypeId { get; set; }

    public decimal GrdId { get; set; }

    public decimal Amount { get; set; }

    public byte? FlagGrdDesig { get; set; }

    public decimal? CityCatId { get; set; }

    public decimal? CityCatAmount { get; set; }

    public decimal? DesigId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public byte? CityCatFlag { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040ExpenseTypeMaster ExpenseType { get; set; } = null!;
}
