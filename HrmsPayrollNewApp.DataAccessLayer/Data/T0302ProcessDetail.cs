using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0302ProcessDetail
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal ProcessTypeId { get; set; }

    public decimal PaymentProcessId { get; set; }

    public decimal AdId { get; set; }

    public decimal Amount { get; set; }

    public decimal Esic { get; set; }

    public decimal CompEsic { get; set; }

    public decimal NetAmount { get; set; }

    public DateTime ModifyDate { get; set; }

    public decimal Tds { get; set; }

    public decimal LoanId { get; set; }

    public decimal LeaveId { get; set; }
}
