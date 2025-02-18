using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0210FinalRetainingPayment
{
    public decimal TranId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal Hours { get; set; }

    public decimal RetainAmount { get; set; }

    public decimal Esic { get; set; }

    public decimal NetAmount { get; set; }

    public decimal AdId { get; set; }

    public DateTime ModifyDate { get; set; }

    public decimal CompEsic { get; set; }

    public decimal Tds { get; set; }

    public decimal Pf { get; set; }

    public decimal WorkingDays { get; set; }

    public decimal CalculateOn { get; set; }

    public int? RetTranId { get; set; }

    public decimal? Vpf { get; set; }

    public decimal? Cpf { get; set; }
}
