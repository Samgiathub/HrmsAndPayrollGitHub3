using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0210LtaMedicalPayment
{
    public decimal LmPayId { get; set; }

    public decimal LmAprId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? SalTranId { get; set; }

    public decimal? SSalTranId { get; set; }

    public decimal? LSalTranId { get; set; }

    public decimal LmPayAmount { get; set; }

    public string LmPayComments { get; set; } = null!;

    public DateTime LmPaymentDate { get; set; }

    public string LmPaymentType { get; set; } = null!;

    public string BankName { get; set; } = null!;

    public string LmChequeNo { get; set; } = null!;

    public string? LmPayCode { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0200MonthlySalaryLeave? LSalTran { get; set; }

    public virtual T0120LtaMedicalApproval LmApr { get; set; } = null!;

    public virtual T0201MonthlySalarySett? SSalTran { get; set; }

    public virtual T0200MonthlySalary? SalTran { get; set; }
}
