using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120InstallmentAmountDetail
{
    public decimal TranId { get; set; }

    public decimal LoanId { get; set; }

    public decimal LoanAprId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal InstallmentAmount { get; set; }
}
