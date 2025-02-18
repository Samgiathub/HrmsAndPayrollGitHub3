using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050ExpenseTypeMaxLimitCountry
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ExpenseTypeId { get; set; }

    public decimal GrdId { get; set; }

    public decimal CountryCatAmount { get; set; }

    public byte FlagGrdDesig { get; set; }

    public decimal CountryCatId { get; set; }

    public decimal? DesigId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040ExpenseTypeMaster ExpenseType { get; set; } = null!;
}
