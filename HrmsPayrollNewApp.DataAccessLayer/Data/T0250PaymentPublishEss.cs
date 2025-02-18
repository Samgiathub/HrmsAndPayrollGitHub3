using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0250PaymentPublishEss
{
    public decimal PublishId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal Month { get; set; }

    public decimal? Year { get; set; }

    public decimal IsPublish { get; set; }

    public decimal UserId { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal EmpId { get; set; }

    public string? Comments { get; set; }

    public decimal AdId { get; set; }

    public string ProcessType { get; set; } = null!;

    public string ProcessTypeId { get; set; } = null!;
}
