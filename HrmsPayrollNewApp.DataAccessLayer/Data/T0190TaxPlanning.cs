using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0190TaxPlanning
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public DateTime ForDate { get; set; }

    public decimal TaxableAmount { get; set; }

    public decimal ItYAmount { get; set; }

    public decimal ItYSurchargeAmount { get; set; }

    public decimal? ItYEdCessAmount { get; set; }

    public decimal ItYFinalAmount { get; set; }

    public decimal ItYPaidAmount { get; set; }

    public byte MonthRemainForSalary { get; set; }

    public decimal ItMAmount { get; set; }

    public decimal ItMSurchargeAmount { get; set; }

    public decimal ItMEdCessAmount { get; set; }

    public decimal ItMFinalAmount { get; set; }

    public byte IsRepeat { get; set; }

    public string ItMultipleMonth { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public string ItDeclarationCalcOn { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
