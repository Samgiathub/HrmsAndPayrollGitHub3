using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050CollectionDetail
{
    public decimal CollectionDetailId { get; set; }

    public decimal? CollectionId { get; set; }

    public decimal? ProjectId { get; set; }

    public string? ServiceType { get; set; }

    public string? ContractType { get; set; }

    public decimal? FedoraCharges { get; set; }

    public decimal? PracticeCollection { get; set; }

    public decimal? TotalCharges { get; set; }

    public decimal? ExchangeRate { get; set; }

    public decimal? TotalFedoraCharges { get; set; }

    public string? OtherRemarks { get; set; }

    public int? Invoice { get; set; }

    public int? Payment { get; set; }
}
