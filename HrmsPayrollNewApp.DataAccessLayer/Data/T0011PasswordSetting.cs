using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0011PasswordSetting
{
    public decimal PasswordId { get; set; }

    public decimal CmpId { get; set; }

    public byte EnableValidation { get; set; }

    public decimal? MinChars { get; set; }

    public byte? UpperChar { get; set; }

    public byte? LowerChar { get; set; }

    public byte? IsDigit { get; set; }

    public byte? SpecialChar { get; set; }

    public string? PasswordFormat { get; set; }

    public decimal? PassExpDays { get; set; }

    public decimal? ReminderDays { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
