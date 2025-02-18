using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050ExpenseTypeMaxKm
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ExpenseTypeId { get; set; }

    public decimal KmRate { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? DesigId { get; set; }

    public byte? FlagGrdDesig { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal MaxKm { get; set; }
}
