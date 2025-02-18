using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040ExpenseTypeMaster
{
    public decimal ExpenseTypeId { get; set; }

    public string ExpenseTypeName { get; set; } = null!;

    public string ExpenseTypeGroup { get; set; } = null!;

    public string? GradeIdMulti { get; set; }

    public decimal CmpId { get; set; }

    public byte GradeWiseExAmount { get; set; }

    public byte? DisplayFromTime { get; set; }

    public byte IsOverlimit { get; set; }

    public byte IsNotPreePostDate { get; set; }

    public byte IsPetrolWise { get; set; }

    public byte IsDeduct { get; set; }

    public decimal? DeductPer { get; set; }

    public byte? TravelMode { get; set; }

    public byte GstApplicable { get; set; }

    public int? TravelTypeId { get; set; }

    public decimal NoOfDays { get; set; }

    public decimal GuestName { get; set; }

    public virtual ICollection<T0050ExpenseTypeMaxLimitCountry> T0050ExpenseTypeMaxLimitCountries { get; set; } = new List<T0050ExpenseTypeMaxLimitCountry>();

    public virtual ICollection<T0050ExpenseTypeMaxLimit> T0050ExpenseTypeMaxLimits { get; set; } = new List<T0050ExpenseTypeMaxLimit>();
}
