import 'package:flutter/material.dart';
import 'legal_document_screen.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Termos de Uso',
      lastUpdated: '04 de junho de 2026',
      sections: [
        LegalSection(
          title: '1. Aceitação dos Termos',
          paragraphs: [
            'Ao criar uma conta e utilizar o Plant Care ("aplicativo"), você concorda em cumprir e estar vinculado a estes Termos de Uso. Se você não concordar com qualquer parte destes termos, não deverá utilizar o aplicativo.',
            'O Plant Care é um aplicativo de monitoramento e cuidado de plantas que oferece funcionalidades como registro de plantas, lembretes de rega, análise de saúde, planos de cuidados e armazenamento de fotos.',
          ],
        ),
        LegalSection(
          title: '2. Cadastro e Conta',
          paragraphs: [
            'Para utilizar o aplicativo, você deve criar uma conta fornecendo informações verdadeiras, precisas e completas. Você é responsável por manter a confidencialidade da sua senha e por todas as atividades realizadas na sua conta.',
            'Você concorda em notificar imediatamente o Plant Care sobre qualquer uso não autorizado da sua conta. O aplicativo não se responsabiliza por perdas ou danos decorrentes do uso não autorizado da sua conta.',
            'O login pode ser realizado por email e senha ou por meio do Google Sign-In, sujeito aos termos do Google.',
          ],
        ),
        LegalSection(
          title: '3. Uso do Aplicativo',
          paragraphs: [
            'O Plant Care é destinado ao uso pessoal e não comercial. Você concorda em não utilizar o aplicativo para fins ilegais, fraudulentos ou que violem direitos de terceiros.',
            'As informações de cuidados de plantas fornecidas pelo aplicativo são apenas orientativas e baseadas em fontes públicas. O aplicativo não garante resultados específicos no cultivo, que dependem de fatores ambientais, climáticos e do cuidado individual do usuário.',
          ],
        ),
        LegalSection(
          title: '4. Conteúdo do Usuário',
          paragraphs: [
            'Você mantém todos os direitos sobre as fotos, descrições e demais conteúdos que adicionar ao aplicativo. Ao enviar conteúdo, você concede ao Plant Care uma licença mundial, não exclusiva e livre de royalties para armazenar, processar e exibir esse conteúdo exclusivamente para o funcionamento do serviço.',
            'Você é o único responsável pelo conteúdo que envia e garante que possui os direitos necessários sobre ele.',
          ],
        ),
        LegalSection(
          title: '5. Privacidade e Proteção de Dados',
          paragraphs: [
            'O tratamento dos seus dados pessoais é regido pela nossa Política de Privacidade, que faz parte integrante destes Termos de Uso. Recomendamos a leitura atenta da Política de Privacidade.',
          ],
        ),
        LegalSection(
          title: '6. Notificações',
          paragraphs: [
            'Ao aceitar estes termos, você concorda em receber notificações push relacionadas ao cuidado das suas plantas (lembretes de rega, alertas de saúde, etc.). Você pode desativar as notificações a qualquer momento nas configurações do dispositivo ou do aplicativo.',
          ],
        ),
        LegalSection(
          title: '7. Cancelamento e Exclusão de Conta',
          paragraphs: [
            'Você pode excluir sua conta a qualquer momento nas configurações do aplicativo. Ao excluir a conta, todos os seus dados pessoais, plantas cadastradas, fotos e histórico serão permanentemente removidos dos nossos servidores.',
          ],
        ),
        LegalSection(
          title: '8. Limitação de Responsabilidade',
          paragraphs: [
            'O Plant Care é fornecido "como está" e "conforme disponibilidade". Não garantimos que o serviço será ininterrupto, seguro ou livre de erros. Não nos responsabilizamos por danos diretos, indiretos, incidentais ou consequenciais decorrentes do uso ou da impossibilidade de uso do aplicativo.',
            'As análises de saúde e planos de cuidados são gerados a partir de bases de dados e regras, podendo conter imprecisões. Use-as como orientação, não como única fonte de decisão.',
          ],
        ),
        LegalSection(
          title: '9. Alterações dos Termos',
          paragraphs: [
            'Podemos atualizar estes Termos de Uso periodicamente. Notificaremos sobre alterações significativas por meio do aplicativo ou por email. O uso continuado do aplicativo após as alterações constitui aceitação dos novos termos.',
          ],
        ),
        LegalSection(
          title: '10. Contato',
          paragraphs: [
            'Em caso de dúvidas sobre estes Termos de Uso, entre em contato pelo email: suporte@plantcare.app',
          ],
        ),
      ],
    );
  }
}
