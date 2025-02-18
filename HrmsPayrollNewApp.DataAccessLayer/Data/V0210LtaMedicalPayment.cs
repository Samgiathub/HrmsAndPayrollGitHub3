using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0210LtaMedicalPayment
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

    public int? TypeId { get; set; }

    public decimal? AprAmount { get; set; }

    public string? AprCode { get; set; }

    public DateTime? AprDate { get; set; }

    public string PStatus { get; set; } = null!;

    public string? TypeName { get; set; }

    public decimal? EmpId { get; set; }
}
