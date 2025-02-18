using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0190TaxImportOnNotEffectSalary
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal AdId { get; set; }

    public decimal Month { get; set; }

    public decimal Year { get; set; }

    public decimal TdsAmount { get; set; }

    public byte IsRepeat { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDatetime { get; set; }

    public string? Comments { get; set; }
}
